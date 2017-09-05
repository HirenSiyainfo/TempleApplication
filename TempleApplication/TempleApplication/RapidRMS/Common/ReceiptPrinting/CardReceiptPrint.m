//
//  CardReceiptPrint.m
//  RapidRMS
//
//  Created by Siya Infotech on 09/06/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "CardReceiptPrint.h"
#import "StarBitmap.h"
#import "RasterDocument.h"
#import "RmsDbController.h"
#import "RasterPrintJob.h"
#import "RasterPrintJobBase.h"



@interface CardReceiptPrint()<UIWebViewDelegate>
{
    RmsDbController *rmsDbController;
}


@end
@implementation CardReceiptPrint

- (instancetype)initWithPortName:(NSString *)portName portSetting:(NSString *)portSettings withPaymentDatail:(NSArray *)paymentDatail tipSetting:(NSNumber *)tipSetting tipsPercentArray:(NSArray *)tipsPercentArray receiptDate:(NSString *)reciptDate
{
    self = [super init];
    if (self) {
        portNameForPrinter = portName;
        portSettingsForPrinter = portSettings;
        strReceiptDate = reciptDate;
        paymentDatailsArray = paymentDatail;
        tipSettings = tipSetting;
        arrTipsPercent = [tipsPercentArray mutableCopy];
        rmsDbController = [RmsDbController sharedRmsDbController];
        self.crmController = [RcrController sharedCrmController];
    }
    return self;
}

#pragma mark - Generate Html

-(NSString *)generateHtmlForCardRecieptForInvoiceNo:(NSString *)strInvoiceNo
{
    NSString *html = @"";
    html = [[NSBundle mainBundle] pathForResource:@"CardReceipt" ofType:@"html"];
    html = [NSString stringWithContentsOfFile:html encoding:NSUTF8StringEncoding error:nil];

    if ((rmsDbController.globalDict)[@"ReceiptMasterInfo"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] count] > 0) {
        html = [html stringByReplacingOccurrencesOfString:@"$$BRANCH_NAME$$" withString:[NSString stringWithFormat:@"%@",(rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"StoreName"]]];
    }
    else
    {
        html = [html stringByReplacingOccurrencesOfString:@"$$BRANCH_NAME$$" withString:[NSString stringWithFormat:@"%@",[[rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"BranchName"]]];
    }
    if ((rmsDbController.globalDict)[@"ReceiptMasterInfo"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] count] > 0) {
        html = [html stringByReplacingOccurrencesOfString:@"$$ADDRESS$$" withString:[NSString stringWithFormat:@"%@",(rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Address"]]];
    }
    else {
        html = [html stringByReplacingOccurrencesOfString:@"$$ADDRESS$$" withString:[NSString stringWithFormat:@"%@%@",[[rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address1"],[[rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address2"]]];
    }
    if ((rmsDbController.globalDict)[@"ReceiptMasterInfo"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] count] > 0) {
        if ((rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Email"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Email"] length] > 0) {
            NSString *email = [NSString stringWithFormat:@"%@", (rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Email"]];
            NSString *phoneNo = [NSString stringWithFormat:@"%@", (rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"PhoneNo"]];
            html =  [html stringByReplacingOccurrencesOfString:@"$$STATE_CITY_ZIPCODE$$" withString:[NSString stringWithFormat:@"%@ - %@",email,phoneNo]];
        }
        else
        {
            NSString *phoneNo = [NSString stringWithFormat:@"%@", (rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"PhoneNo"]];
            html =  [html stringByReplacingOccurrencesOfString:@"$$STATE_CITY_ZIPCODE$$" withString:[NSString stringWithFormat:@"%@",phoneNo]];
        }
    }
    else {
        html = [html stringByReplacingOccurrencesOfString:@"$$STATE_CITY_ZIPCODE$$" withString:[NSString stringWithFormat:@"%@%@%@",[[rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"City"],[[rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"State"],[[rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"ZipCode"]]];
    }
    html = [html stringByReplacingOccurrencesOfString:@"$$TRANSACTION_NO$$" withString:[NSString stringWithFormat:@"%@",strInvoiceNo]];
    html = [html stringByReplacingOccurrencesOfString:@"$$USER_NAME$$" withString:[NSString stringWithFormat:@"%@",[[rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserName"]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$REGISTER_NAME$$" withString:[NSString stringWithFormat:@"%@",(rmsDbController.globalDict)[@"RegisterName"]]];
    
    if (strReceiptDate) {
        html = [html stringByReplacingOccurrencesOfString:@"$$DATE$$" withString:strReceiptDate];
    }
    else
    {
        html = [html stringByReplacingOccurrencesOfString:@"$$DATE$$" withString:[NSString stringWithFormat:@"%@",[self getCurrentDate]]];
    }
    
    html = [html stringByReplacingOccurrencesOfString:@"$$CARD_DATA$$" withString:[NSString stringWithFormat:@"%@",[self generateHtmlForCardData]]];
    html = [html stringByReplacingOccurrencesOfString:@"$$TIPS_DATA$$" withString:[NSString stringWithFormat:@"%@",[self generateHtmlForTips]]];
    
    
    if ((rmsDbController.globalDict)[@"ReceiptMasterInfo"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] count] > 0 && (rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"ThanksNote"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"ThanksNote"] length] > 0) {
        NSString *thanksMessage = [NSString stringWithFormat:@"%@", (rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"ThanksNote"]];
        html = [html stringByReplacingOccurrencesOfString:@"$$HELPMESSAGE1$$" withString:[NSString stringWithFormat:@"%@",thanksMessage]];
        html = [html stringByReplacingOccurrencesOfString:@"$$BRANCH_NAME$$" withString:@""];
        html = [html stringByReplacingOccurrencesOfString:@"$$HELPMESSAGE2$$" withString:@""];
        html = [html stringByReplacingOccurrencesOfString:@"$$HELPMESSAGE3$$" withString:@""];
    }
    else {
        html = [html stringByReplacingOccurrencesOfString:@"$$HELPMESSAGE1$$" withString:[NSString stringWithFormat:@"%@",[rmsDbController.globalDict valueForKey:@"BranchInfo"] [@"HelpMessage1"]]];
        html = [html stringByReplacingOccurrencesOfString:@"$$BRANCH_NAME$$" withString:[NSString stringWithFormat:@"%@",[rmsDbController.globalDict valueForKey:@"BranchInfo"] [@"BranchName"]]];
        html = [html stringByReplacingOccurrencesOfString:@"$$HELPMESSAGE2$$" withString:[NSString stringWithFormat:@"%@",[rmsDbController.globalDict valueForKey:@"BranchInfo"] [@"HelpMessage2"]]];
        html = [html stringByReplacingOccurrencesOfString:@"$$HELPMESSAGE3$$" withString:[NSString stringWithFormat:@"%@",[rmsDbController.globalDict valueForKey:@"BranchInfo"] [@"HelpMessage3"]]];
    }

    NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths.firstObject;
    html = [documentsDirectory stringByAppendingPathComponent:@"CardReceipt.html"];

    html = [self writeCardRecieptDataOnCacheDirectory:data fromHtml:html];
    return html;
}

-(NSString *)writeCardRecieptDataOnCacheDirectory:(NSData *)data fromHtml:(NSString *)html
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:html])
    {
        [[NSFileManager defaultManager] removeItemAtPath:html error:nil];
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths.firstObject;
    html = [documentsDirectory stringByAppendingPathComponent:@"CardReceipt.html"];
    [data writeToFile:html atomically:YES];
    return html;
}

- (NSString *)getCurrentDate
{
    NSDate * date = [NSDate date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"hh:mm a";
    return [dateFormatter stringFromDate:date];
}

- (NSString *)generateHtmlForCardData
{
    NSString *html = @"";
    for(int i = 0;i<paymentDatailsArray.count;i++)
    {
        NSMutableDictionary *paymentDict = paymentDatailsArray[i];
        if([[paymentDict valueForKey:@"AuthCode"]length]>0 && [[paymentDict valueForKey:@"CardType"]length]>0 && [[paymentDict valueForKey:@"TransactionNo"]length]>0 && [[paymentDict valueForKey:@"AccNo"]length]>0)
        {
            html = [html stringByAppendingFormat:@"<table style=\" width:300px; margin:auto; font-size: 15px;\" border=\"0\">"];
            html = [html stringByAppendingFormat:@"<tr><td colspan=\"2\">Card Holder Name &nbsp; : %@ </td></tr>",[paymentDict valueForKey:@"CardHolderName"]];
            html = [html stringByAppendingFormat:@"<tr><td colspan=\"2\">Card Number &nbsp; : %@ </td></tr>",[paymentDict valueForKey:@"AccNo"]];
            if (![[paymentDict valueForKey:@"AuthCode"] isEqualToString:@"-"])
            {
                html = [html stringByAppendingFormat:@"<tr><td colspan=\"2\">Auth Code &nbsp; : %@ </td></tr>",[paymentDict valueForKey:@"AuthCode"]];
            }
            
            NSString *strBillAmount=[NSString stringWithFormat:@"%@",[paymentDict valueForKey:@"BillAmount"]];
            NSNumber *numAmount=@(strBillAmount.floatValue);
            NSString *tenderAmount =[self.crmController.currencyFormatter stringFromNumber:numAmount];
            
            html = [html stringByAppendingFormat:@"<tr><td colspan=\"2\">Amount &nbsp; : %@ </td></tr>",tenderAmount];
            html = [html stringByAppendingFormat:@"<tr><td colspan=\"2\">&nbsp;</td></tr>"];
            float tipAmount = [self getSumOfTheValue:@"TipsAmount" forBillDetail:paymentDatailsArray];
            
            if(tipAmount > 0){
                html = [html stringByAppendingFormat:@"<tr><td colspan=\"2\"><div style=\"float:left;\">Tip &nbsp; :</div><div style=\" float:left; border-bottom:1px solid #000; ; width:60%%;\">%.2f</div></td></tr>",tipAmount];
                html = [html stringByAppendingFormat:@"<tr><td colspan=\"2\">&nbsp;</td></tr>"];
                
                float tipAmount = [[paymentDict valueForKey:@"TipsAmount"] floatValue];
                float totalAmount2 = [[paymentDict valueForKey:@"BillAmount"] floatValue] + tipAmount;
                
                html = [html stringByAppendingFormat:@"<tr><td colspan=\"2\"><div style=\"float:left;\"><strong>Total</strong> &nbsp; :</div><div style=\" float:left; border-bottom:1px solid #000; ; width:60%%;\">%.2f</div></td></tr>",totalAmount2];
                html = [html stringByAppendingFormat:@"<tr><td colspan=\"2\">&nbsp;</td></tr>"];
            }
            else
            {
                if([tipSettings isEqual: @(1)])
                {
                    html = [html stringByAppendingFormat:@"<tr><td colspan=\"2\"><div style=\"float:left;\">Tip &nbsp; :</div><div style=\" float:left; border-bottom:1px solid #000; ; width:60%%; height: 12px;\"></div></td></tr>"];
                    html = [html stringByAppendingFormat:@"<tr><td colspan=\"2\">&nbsp;</td></tr>"];
                    html = [html stringByAppendingFormat:@"<tr><td colspan=\"2\"><div style=\"float:left;\"><strong>Total</strong> &nbsp; :</div><div style=\" float:left; border-bottom:1px solid #000; ; width:60%%; height: 12px;\"></div></td></tr>"];
                    html = [html stringByAppendingFormat:@"<tr><td colspan=\"2\">&nbsp;</td></tr>"];
                }
                html = [html stringByAppendingFormat:@"<tr><td colspan=\"2\" style=\"padding-bottom:0px; border-bottom:1px dotted #000;\">&nbsp;</td></tr><tr><td colspan=\"2\">&nbsp;</td></tr></table>"];
            }
        }
    }
    return html;
}

-(CGFloat)getSumOfTheValue:(NSString *)key forBillDetail:(NSArray *)billDetailArray
{
    CGFloat sum  = 0.00;
    for (NSDictionary *dictionary in billDetailArray) {
        sum += [[dictionary valueForKey:key] floatValue];
    }
    return sum;
}

- (NSString *)generateHtmlForTips
{
    NSString *html = @"";
    float tipAmount = [self getSumOfTheValue:@"TipsAmount" forBillDetail:paymentDatailsArray];
    if (tipAmount > 0)
    {
    }
    else
    {
        if([tipSettings isEqual: @(1)]){
            html = [html stringByAppendingFormat:@"<table width=\"60%%\" align=\"center\">"];
            for(int i=0;i<arrTipsPercent.count;i++){
                NSMutableDictionary *dicTips = arrTipsPercent[i];
                html = [html stringByAppendingFormat:@"<tr><td width=\"100\">%@%%</td>",[dicTips valueForKey:@"TipsPercentage"]];
                html = [html stringByAppendingFormat:@"<td width=\"100\">%@</td></tr>",[rmsDbController applyCurrencyFomatter:[dicTips valueForKey:@"TipsAmount"]]];
            }
            html = [html stringByAppendingFormat:@"</table>"];
        }
    }
    return html;
}

#pragma mark - TCP Printing

- (void)printCardReceiptFromHtml:(NSString *)path withPort:portName portSettings:portSettings
{
    printJob = [[PrintJobBase alloc] initWithPort:portName portSettings:portSettings deviceName:@"" withDelegate:nil];
    [self LoadReceiptHtml:path];
}

-(void)LoadReceiptHtml:(NSString *)path{
    NSData *myData = [NSData dataWithContentsOfFile:path];
    NSString *stringHtml = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];
    webViewForTCPPrinting = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, 576, 200)];
    webViewForTCPPrinting.delegate = self;
    [webViewForTCPPrinting loadHTMLString:stringHtml baseURL:nil];
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
}

#pragma mark - Print Image From Html WebView

-(void)printImagefromWebview:(UIWebView *)pwebview{
    UIImage *img = [UIImage imageWithData:[self getImageFromView:pwebview]];
    UIImage *printImage = [self imageResize:img andResizeTo:CGSizeMake(img.size.width * 1.5, img.size.height * 1.5)];
    [printJob printImage:printImage];
    [printJob cutPaper:PC_PARTIAL_CUT_WITH_FEED];
    [printJob firePrint];
}

#pragma mark - Image Resizing

- (UIImage *)imageResize:(UIImage*)img andResizeTo:(CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    [img drawInRect:CGRectMake(-140,0,newSize.width,newSize.height)];
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

- (void)configureInvoiceReceiptSection {
    _sections = @[
                  @(CardReceiptSectionReceiptHeader),
                  @(CardReceiptSectionReceiptInfo),
                  @(CardReceiptSectionCardDetail),
                  @(CardReceiptSectionSignature),
                  @(CardReceiptSectionThanksMessage),
                  ];
    
    
    NSArray *receiptHeaderSectionFields = @[@(CardReceiptFieldStoreName),
                                          @(CardReceiptFieldAddressline1),
                                          @(CardReceiptFieldAddressline2)];
    NSArray *receiptInfoSectionFields = @[@(CardReceiptFieldReceiptName),
                                          @(CardReceiptFieldInvoiceNo),
                                          @(CardReceiptFieldCashierAndRegisterName),
                                          @(CardReceiptFieldTransactionDate),
                                          @(CardReceiptFieldPrintDate),
                                          ];
    NSArray *cardDetailSectionFields = @[@(CardReceiptFieldCardDetails),
                                         ];
    NSArray *cardHolderSignatureSectionFields = @[@(CardReceiptFieldCardHolderSignature),
                                            ];
    NSArray *thanksMessageSectionFields = @[@(CardReceiptFieldThanksMessage),
                                         ];

    /// field detail
    _fields = @[
                receiptHeaderSectionFields,
                receiptInfoSectionFields,
                cardDetailSectionFields,
                cardHolderSignatureSectionFields,
                thanksMessageSectionFields,
                ];
}


#pragma mark - Bluetooth Printing

- (void)printCardReceiptForInvoiceNo:(NSString *)strInvoiceNo withDelegate:(id)delegate
{
        [self configureInvoiceReceiptSection];
        [self configurePrint:portSettingsForPrinter portName:portNameForPrinter withDelegate:delegate];
        strInvoice = strInvoiceNo;
        NSInteger sectionCount = _sections.count;
        for (int i = 0; i < sectionCount; i++) {
            CardReceiptSection section = [self sectionAtSectionIndex:i];
            [self printHeaderForSection:section];
            [self printCommandForSectionAtIndex:i];
            [self printFooterForSection:section];
        }
        
        [self concludePrint];
//    int totlength = 48;  //star printer 48 char length fix
//    NSMutableData *commands = [[NSMutableData alloc] init];
//    [self generatePrintCardReceiptCommands:commands totlength:totlength forInvoiceNo:strInvoiceNo];
//    [PrinterFunctions sendCommand:commands portName:portNameForPrinter portSettings:portSettingsForPrinter timeoutMillis:10000 deviceName:@"Printer"];
}

#pragma mark - Printing
- (NSInteger)sectionAtSectionIndex:(NSInteger)sectionIndex {
    return [_sections[sectionIndex] integerValue];
}

-(void)printHeaderForSection:(NSInteger)section
{
        switch (section) {
            case CardReceiptSectionReceiptHeader:
                [self printHeaderForReceiptSectionReceiptHeader];
                break;
                
            case CardReceiptSectionReceiptInfo:
                [self printHeaderForReceiptSectionReceiptInfo];
                break;
                
            case CardReceiptSectionCardDetail:
                [self printHeaderForReceiptSectionCardDetail];
                break;
                
            case CardReceiptSectionSignature:
                [self printHeaderForReceiptSectionSignature];
                break;
                
            case CardReceiptSectionThanksMessage:
                [self printHeaderForReceiptSectionThanksMessage];
                break;

            default:
                break;
        }
}

- (void)printFooterForSection:(NSInteger)section {
        switch (section) {
            case CardReceiptSectionReceiptHeader:
                [self printFooterForReceiptSectionReceiptHeader];
                break;
                
            case CardReceiptSectionReceiptInfo:
                [self printFooterForReceiptSectionReceiptInfo];
                break;
                
            case CardReceiptSectionCardDetail:
                [self printFooterForReceiptSectionCardDetail];
                break;
                
            case CardReceiptSectionSignature:
                [self printFooterForReceiptSectionSignature];
                break;
                
            case CardReceiptSectionThanksMessage:
                [self printFooterForReceiptSectionThanksMessage];
                break;
                
            default:
                break;
        }
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
    CardReceiptFeild fieldId = fieldNumber.integerValue;
    [self printFieldWithId:fieldId];
}

- (void)printFieldWithId:(NSInteger)fieldId
{
    switch (fieldId) {
        case CardReceiptFieldStoreName:
            [self printStoreName];
            break;
            
        case CardReceiptFieldAddressline1:
            [self printAddressline1];
            break;
            
        case CardReceiptFieldAddressline2:
            [self printAddressline2];
            break;
            
        case CardReceiptFieldReceiptName:
            [self printReceiptName];
            break;
            
        case CardReceiptFieldInvoiceNo:
            [self printInvoiceNo];
            break;
            
        case CardReceiptFieldCashierAndRegisterName:
            [self printCashierAndRegisterName];
            break;
            
        case CardReceiptFieldTransactionDate:
            [self printTrasactionDateAndTime];
            break;
            
        case CardReceiptFieldPrintDate:
            [self printDateAndTime];
            break;
            
        case CardReceiptFieldCardDetails:
            [self printCardDetails];
            break;
            
        case CardReceiptFieldCardHolderSignature:
            [self printCardHolderSignature];
            break;

        case CardReceiptFieldThanksMessage:
            [self printThanksMessage];
            break;
            
        default:
            NSLog(@"Implement Field - %@", @(fieldId));
            break;
    }
    
}

- (void)configurePrint:(NSString *)portSettings portName:(NSString *)portName withDelegate:(id)delegate
{
    BOOL isBlueToothPrinter = [portName isEqualToString:@"BT:Star Micronics"];
    
    if (isBlueToothPrinter) {
        printJob = [[PrintJobBase alloc] initWithPort:portName portSettings:portSettings  deviceName:@"Printer" withDelegate:delegate];
        [printJob enableSlashedZero:YES];
    }
    else
    {
        printJob = [[RasterPrintJobBase alloc] initWithPort:portName portSettings:portSettings deviceName:@"Printer" withDelegate:delegate];
    }
}

- (void)concludePrint
{
    [printJob cutPaper:PC_PARTIAL_CUT_WITH_FEED];
    [printJob firePrint];
    printJob = nil;
}

#pragma mark - Header Printing

-(void)printHeaderForReceiptSectionReceiptHeader {
    
}

-(void)printHeaderForReceiptSectionReceiptInfo {
    
}

-(void)printHeaderForReceiptSectionCardDetail {
    
    [printJob printSeparator];
    [printJob setTextAlignment:TA_CENTER];
    if (self.isVoidCardReceipt == TRUE) {
        [printJob printLine:[NSString stringWithFormat:@"%@",@"Void"]];
    }
}

-(void)printHeaderForReceiptSectionSignature {
    
}

-(void)printHeaderForReceiptSectionThanksMessage {
    
}

#pragma mark - Footer Printing
-(void)printFooterForReceiptSectionReceiptHeader {
    
}

-(void)printFooterForReceiptSectionReceiptInfo {
}

-(void)printFooterForReceiptSectionCardDetail {
    
}

-(void)printFooterForReceiptSectionSignature {
    
}

-(void)printFooterForReceiptSectionThanksMessage {
    
}

#pragma mark - Field Printing

-(void)printStoreName {
    [printJob setTextAlignment:TA_CENTER];
    if ((rmsDbController.globalDict)[@"ReceiptMasterInfo"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] count] > 0) {
        [printJob printLine:(rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"StoreName"]];
    }
    else
    {
        [printJob printLine:[NSString stringWithFormat:@"%@",[[rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"BranchName"]]];
    }
}

-(void)printAddressline1 {
    [printJob setTextAlignment:TA_CENTER];
    NSString *addressLine1;
    if ((rmsDbController.globalDict)[@"ReceiptMasterInfo"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] count] > 0) {
        addressLine1 = [NSString stringWithFormat:@"%@", (rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Address"]];
    }
    else {
        addressLine1 = [NSString stringWithFormat:@"%@  , %@", [[rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address1"],[[rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address2"]];
    }
    [printJob printLine:addressLine1];
}

-(void)printAddressline2 {
    [printJob setTextAlignment:TA_CENTER];
    if ((rmsDbController.globalDict)[@"ReceiptMasterInfo"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] count] > 0) {
        if ((rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Email"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Email"] length] > 0) {
            NSString *email = [NSString stringWithFormat:@"%@", (rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Email"]];
            NSString *phoneNo = [NSString stringWithFormat:@"%@", (rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"PhoneNo"]];
            [printJob printLine:email];
            [printJob printLine:phoneNo];
        }
        else
        {
            NSString *phoneNo = [NSString stringWithFormat:@"%@", (rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"PhoneNo"]];
            [printJob printLine:phoneNo];
        }
    }
    else {
        NSString *addressLine2 = [NSString stringWithFormat:@"%@ , %@ - %@", [[rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"City"],[[rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"State"],[[rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"ZipCode"]];
        [printJob printLine:addressLine2];
    }
}

-(void)printReceiptName {
    [printJob setTextAlignment:TA_CENTER];
    [printJob enableInvertColor:YES];
    [printJob printLine:@" Card Receipt "];
    [printJob enableInvertColor:NO];
}

-(void)printInvoiceNo {
    [printJob setTextAlignment:TA_LEFT];
    [printJob printLine:[NSString stringWithFormat:@"Invoice #: %@",strInvoice]];
    [printJob enableInvertColor:NO];
}

-(void)printCashierAndRegisterName {
    NSString *salesPersonName = [NSString stringWithFormat:@"%@",[[rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserName"]];
    NSString *strCashier = [NSString stringWithFormat:@"Cashier #: %@",salesPersonName];
    NSString *strRegister = [NSString stringWithFormat:@"Register #: %@",(rmsDbController.globalDict)[@"RegisterName"]];
    [self defaultFormatForReceptInfo];
    [printJob printText1:strCashier text2:strRegister];
}

-(void)printTrasactionDateAndTime
{
    [printJob setTextAlignment:TA_LEFT];
    if (strReceiptDate) {
        [printJob printLine:[NSString stringWithFormat:@"Trnx Date:%@",strReceiptDate]];
    }
}

-(void)printDateAndTime
{
    [printJob setTextAlignment:TA_LEFT];
    NSDate * date = [NSDate date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"hh:mm a";
    NSString *printDate = [dateFormatter stringFromDate:date];
    NSString *printTime = [timeFormatter stringFromDate:date];
    [printJob printLine:[NSString stringWithFormat:@"Current Date:%@ %@\r\n",printDate,printTime]];
}

-(void)printCardDetails
{
    for(int i = 0;i<paymentDatailsArray.count;i++)
    {
        NSMutableDictionary *paymentDict = paymentDatailsArray[i];
        
        if([[paymentDict valueForKey:@"AuthCode"]length]>0 && [[paymentDict valueForKey:@"CardType"]length]>0 && [[paymentDict valueForKey:@"TransactionNo"]length]>0 && [[paymentDict valueForKey:@"AccNo"]length]>0)
        {
            [printJob printSeparator];
            NSString *strAccountNo = [NSString stringWithFormat:@"%@",[paymentDict valueForKey:@"AccNo"]];
            NSString *strBillAmount=[NSString stringWithFormat:@"%@",[paymentDict valueForKey:@"BillAmount"]];
            NSNumber *numAmount=@(strBillAmount.floatValue);
            NSString *tenderAmount =[self.crmController.currencyFormatter stringFromNumber:numAmount];
            [printJob printLine:@""];
            [printJob printLine:[NSString stringWithFormat:@"Card Holder Name: %@",[paymentDict valueForKey:@"CardHolderName"]]];
            [printJob printLine:[NSString stringWithFormat:@"Card Number: %@",strAccountNo]];

            if (![[paymentDict valueForKey:@"AuthCode"] isEqualToString:@"-"])
            {
                [printJob printLine:[NSString stringWithFormat:@"Auth Code: %@",[paymentDict valueForKey:@"AuthCode"]]];
            }
            
            [printJob printLine:[NSString stringWithFormat:@"Amount: %@",tenderAmount]];

            CGFloat tipAmount = [[paymentDict valueForKey:@"TipsAmount"] floatValue];
            if(tipAmount>0){
                
                NSNumber *numTipAmount = [NSNumber numberWithFloat:tipAmount];
                NSString *tenderTipAmount =[self.crmController.currencyFormatter stringFromNumber:numTipAmount];
                [printJob printLine:[NSString stringWithFormat:@"Tip: %@",tenderTipAmount]];
                
                float totalAmount2 = strBillAmount.floatValue + tipAmount;
                [printJob enableBold:YES];
                NSNumber *numtotalAmount2 = @(totalAmount2);
                NSString *tenderTotalAmount2 =[self.crmController.currencyFormatter stringFromNumber:numtotalAmount2];
                [printJob printLine:[NSString stringWithFormat:@"Total: %@",tenderTotalAmount2]];
                [printJob enableBold:NO];
            }
            else
            {
                if([tipSettings isEqual: @(1)])
                {
                    [printJob printLine:@""];
                    [printJob printLine:@"Tip :_________________________"];
                    [printJob enableBold:YES];
                    [printJob printLine:@"Total :_________________________"];
                    [printJob printLine:@""];
                    [printJob enableBold:NO];
                    
                    for(int i=0;i<arrTipsPercent.count;i++) {
                        [printJob setTextAlignment:TA_CENTER];
                        NSMutableDictionary *dicTips = arrTipsPercent[i];
                        NSString *strTipsPercentage = [NSString stringWithFormat:@"%@%%",[dicTips valueForKey:@"TipsPercentage"]];
                        NSNumber *tipsAmountNum = @([[dicTips valueForKey:@"TipsAmount"] floatValue]);
                        NSString *strTipsAmount =[self.crmController.currencyFormatter stringFromNumber:tipsAmountNum];
                        [self defaultFormatForTipsDetails];
                        [printJob printText1:strTipsPercentage text2:@"" text3:strTipsAmount];
                    }
                }
            }
        }
    }
    [printJob printSeparator];
}

-(void)printCardHolderSignature {
    [printJob setTextAlignment:TA_RIGHT];
    [printJob printLine:@""];
    [printJob printLine:@"Cardholder Signature"];
    [printJob printLine:@""];
    [printJob printLine:@""];
    [printJob printLine:@""];
    
    [printJob printLine:@" X  ________________________________________"];
    [printJob printLine:@""];
    [printJob printLine:@""];
    
    [printJob setTextAlignment:TA_LEFT];
    [printJob printLine:@"I AGREE TO PAY ABOVE TOTAL AMOUNT ACCORDING TO CARD ISSUER AGREEMENT."];
    [printJob printLine:@""];
}

- (NSMutableAttributedString *)attributedStringWithBiggerSizeOfFontFromString:(NSString *)string
{
    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[string dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType  } documentAttributes:nil error:nil];
    
    [attrStr enumerateAttributesInRange: NSMakeRange(0, attrStr.string.length)
                                options:NSAttributedStringEnumerationReverse usingBlock:
     ^(NSDictionary *attributes, NSRange range, BOOL *stop) {
         UIFont *font = [attributes valueForKey:@"NSFont"];
         UIFont *newFont = [UIFont fontWithName:font.fontName size:25];
         [attrStr addAttribute:NSFontAttributeName value:newFont range:range];
     }];
    return attrStr;
}

-(void)printThanksMessage {
    [printJob setTextAlignment:TA_CENTER];
    if ((rmsDbController.globalDict)[@"ReceiptMasterInfo"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] count] > 0 && (rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"ThanksNote"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"ThanksNote"] length] > 0) {
        NSString *thanksMessage = [NSString stringWithFormat:@"%@", (rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"ThanksNote"]];
        NSMutableAttributedString *attrStr = [self attributedStringWithBiggerSizeOfFontFromString:thanksMessage];
        [printJob beginRasterModePrinting];
        [printJob printAttributedStringLine:attrStr];
        [printJob endRasterModePrinting];
    }
    else {
        if ([[rmsDbController.globalDict valueForKey:@"BranchInfo"] [@"HelpMessage1"] length] > 0)
        {
            [printJob printLine:[NSString stringWithFormat:@"%@",[rmsDbController.globalDict valueForKey:@"BranchInfo"] [@"HelpMessage1"]]];
        }
        [printJob printLine:[NSString stringWithFormat:@"%@",[rmsDbController.globalDict valueForKey:@"BranchInfo"] [@"BranchName"]]];
        if ([[rmsDbController.globalDict valueForKey:@"BranchInfo"] [@"HelpMessage2"] length] > 0)
        {
            [printJob printLine:[NSString stringWithFormat:@"%@",[rmsDbController.globalDict valueForKey:@"BranchInfo"] [@"HelpMessage2"]]];
        }
        if ([[rmsDbController.globalDict valueForKey:@"BranchInfo"] [@"HelpMessage3"] length] > 0)
        {
            [printJob printLine:[NSString stringWithFormat:@"%@",[rmsDbController.globalDict valueForKey:@"BranchInfo"] [@"HelpMessage3"]]];
        }
    }
    [printJob printLine:@""];
    [printJob printBarCode:strInvoice];
}


#pragma mark - Default Formate For Printing

- (void)defaultFormatForReceptInfo
{
    columnWidths[0] = 18;
    columnWidths[1] = 29;
    columnAlignments[0] = CRAlignmentLeft;
    columnAlignments[1] = CRAlignmentRight;
    [printJob setColumnWidths:columnWidths columnAlignments:columnAlignments];
}

- (void)defaultFormatForTipsDetails
{
    columnWidths[0] = 23;
    columnWidths[1] = 0;
    columnWidths[2] = 23;
    columnAlignments[0] = CRAlignmentRight;
    columnAlignments[1] = CRAlignmentLeft;
    columnAlignments[2] = CRAlignmentLeft;
    [printJob setColumnWidths:columnWidths columnAlignments:columnAlignments];
}

- (void)generatePrintCardReceiptCommands:(NSMutableData *)commands totlength:(int)totlength forInvoiceNo:(NSString *)strInvoiceNo
{
    [commands appendBytes:"\x1b\x1d\x61\x01"
                   length:sizeof("\x1b\x1d\x61\x01") - 1];    // center
    
    [commands appendData:[[NSString stringWithFormat:@"%@\r\n",[[rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"BranchName"]] dataUsingEncoding:NSASCIIStringEncoding]];
    [commands appendData:[[NSString stringWithFormat:@"%@ , %@\r\n%@, %@ - %@\r\n\r\n",[[rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address1"],[[rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address2"],[[rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"City"],[[rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"State"],[[rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"ZipCode"]] dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x1d\x61\x01"
                   length:sizeof("\x1b\x1d\x61\x01") - 1];    // Alignment(center)
    
    [commands appendData:[@"\x1b\x34 Card Receipt \x1b\x35\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x44\x02\x10\x22\x00"
                   length:sizeof("\x1b\x44\x02\x10\x22\x00") - 1];    // SetHT
    
    [commands appendBytes:"\x1b\x1d\x61\x00"
                   length:sizeof("\x1b\x1d\x61\x00") - 1];    // Alignment(left)
    
    [commands appendData:[[NSString stringWithFormat:@"Invoice #: %@\r\n",strInvoiceNo] dataUsingEncoding:NSASCIIStringEncoding]];
    
    NSString *salesPersonName=[NSString stringWithFormat:@"%@",[[rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserName"]];
    
    [commands appendBytes:"\x1b\x1d\x61\x02"
                   length:sizeof("\x1b\x1d\x61\x02") - 1];    // Alignment(right)
    
    [commands appendData:[[NSString stringWithFormat:@"Cashier #: %@",salesPersonName] dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[[NSString stringWithFormat:@"      Register #:%@\r\n",(rmsDbController.globalDict)[@"RegisterName"]]dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x1d\x61\x00"
                   length:sizeof("\x1b\x1d\x61\x00") - 1];    // Alignment(left)

    if (strReceiptDate) {
        [commands appendData:[[NSString stringWithFormat:@"Date:%@\r\n",strReceiptDate]dataUsingEncoding:NSASCIIStringEncoding]];
    }
    else
    {
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
        
        [commands appendData:[[NSString stringWithFormat:@"Date:%@ %@\r\n",printDate,printTime]dataUsingEncoding:NSASCIIStringEncoding]];
    }
    
    for(int i = 0;i<paymentDatailsArray.count;i++)
    {
        NSMutableDictionary *paymentDict = paymentDatailsArray[i];
        
        if([[paymentDict valueForKey:@"AuthCode"]length]>0 && [[paymentDict valueForKey:@"CardType"]length]>0 && [[paymentDict valueForKey:@"TransactionNo"]length]>0 && [[paymentDict valueForKey:@"AccNo"]length]>0)
        {
            [commands appendData:[@"------------------------------------------------\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
            NSString *strAccountNo = [NSString stringWithFormat:@"%@",[paymentDict valueForKey:@"AccNo"]];
            NSString *strBillAmount=[NSString stringWithFormat:@"%@",[paymentDict valueForKey:@"BillAmount"]];
            NSNumber *numAmount=@(strBillAmount.floatValue);
            NSString *tenderAmount =[self.crmController.currencyFormatter stringFromNumber:numAmount];
            [commands appendData:[[NSString stringWithFormat:@"Card Holder Name :   %@\r\n",[paymentDict valueForKey:@"CardHolderName"]] dataUsingEncoding:NSASCIIStringEncoding]];
            [commands appendData:[[NSString stringWithFormat:@"Card Number      : %@\r\n",strAccountNo] dataUsingEncoding:NSASCIIStringEncoding]];
            if (![[paymentDict valueForKey:@"AuthCode"] isEqualToString:@"-"])
            {
                [commands appendData:[[NSString stringWithFormat:@"Auth Code : %@\r\n",[paymentDict valueForKey:@"AuthCode"]] dataUsingEncoding:NSASCIIStringEncoding]];
            }
            [commands appendData:[[NSString stringWithFormat:@"Amount    : %@\r\n",tenderAmount] dataUsingEncoding:NSASCIIStringEncoding]];
            
            
            CGFloat tipAmount = [[paymentDict valueForKey:@"TipsAmount"] floatValue];
            if(tipAmount>0){
                [commands appendData:[[NSString stringWithFormat:@"Tip : $%.2f\r\n",tipAmount] dataUsingEncoding:NSASCIIStringEncoding]];
                
                float totalAmount2 = strBillAmount.floatValue + tipAmount;
                
                [commands appendBytes:"\x1b\x45"
                               length:sizeof("\x1b\x45") - 1];    // SetBold
                [commands appendData:[[NSString stringWithFormat:@"Total : $%.2f\r\n",totalAmount2] dataUsingEncoding:NSASCIIStringEncoding]];
                [commands appendBytes:"\x1b\x46"
                               length:sizeof("\x1b\x46") - 1];// CancelBold
            }
            else
            {
                if([tipSettings isEqual: @(1)])
                {
                    [commands appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSASCIIStringEncoding]];
                    [commands appendData:[[NSString stringWithFormat:@"Tip :_________________________\r\n\r\n"] dataUsingEncoding:NSASCIIStringEncoding]];
                    [commands appendBytes:"\x1b\x45"
                                   length:sizeof("\x1b\x45") - 1];    // SetBold
                    [commands appendData:[[NSString stringWithFormat:@"Total :_________________________\r\n\r\n\r\n"] dataUsingEncoding:NSASCIIStringEncoding]];
                    [commands appendBytes:"\x1b\x46"
                                   length:sizeof("\x1b\x46") - 1];// CancelBold
                    
                    for(int i=0;i<arrTipsPercent.count;i++){
                        
                        NSMutableDictionary *dicTips = arrTipsPercent[i];
                        
                        NSString *stingTips = [NSString stringWithFormat:@"%@%%      $%@\r\n",[dicTips valueForKey:@"TipsPercentage"],[dicTips valueForKey:@"TipsAmount"]];
                        
                        [commands appendBytes:"\x1b\x1d\x61\x01"
                                       length:sizeof("\x1b\x1d\x61\x01") - 1];    // Alignment(center)
                        
                        [commands appendData:[stingTips dataUsingEncoding:NSASCIIStringEncoding]];
                    }
                }
            }
        }
    }
    
    [commands appendData:[@"------------------------------------------------\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    if([tipSettings isEqual: @(1)]){
        [commands appendData:[@"\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    }
    
    else{
        [commands appendData:[@"\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    }
    
    [commands appendBytes:"\x1b\x1d\x61\x02"
                   length:sizeof("\x1b\x1d\x61\x02") - 1];    // Alignment(right)
    
    [commands appendData:[@"Cardholder Signature \r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    [commands appendData:[@"\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    [commands appendData:[@"\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@" X  ________________________________________\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x1d\x61\x00"
                   length:sizeof("\x1b\x1d\x61\x00") - 1];    // Alignment(left)
    
    [commands appendData:[@" I AGREE TO PAY ABOVE TOTAL AMOUNT ACCORDING TO \r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@" CARD ISSUER AGREEMENT. \r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x1d\x61\x01"
                   length:sizeof("\x1b\x1d\x61\x01") - 1];    // Alignment(center)
    
    [commands appendData:[@" Thank You for Shopping \r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    NSString *strBrnName=[NSString stringWithFormat:@"%@\r\n",[[rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"BranchName"]] ;
    
    [commands appendData:[strBrnName dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@" We hope you'll come back soon! \r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    //    NSString *textToBarCode = @"AbCdEf123987"; //@"12ab34cd56";
    [commands appendData:[@"\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [self printBarCode:strInvoiceNo commands:commands];
    
    [commands appendBytes:"\x1b\x64\x02"
                   length:sizeof("\x1b\x64\x02") - 1];  //Cut Paper
}

- (void)printBarCode:(NSString *)textToBarCode commands:(NSMutableData *)commands
{
    NSData *barCodeCommand = [[NSString stringWithFormat:@"\x1b\x62\x06\x02\x02\x50%@\x1e\r\n", textToBarCode] dataUsingEncoding:NSASCIIStringEncoding];
    [commands appendData:barCodeCommand];
}


@end
