//
//  CS_ReportGenerator.m
//  RapidRMS
//
//  Created by siya-IOS5 on 12/29/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "CS_ReportGenerator.h"
#import "CS_Item.h"
#import "CS_Invoice.h"
#import "CS_Item.h"
#import "CL_CustomerSearchData.h"
#import "CL_HouseCharge.h"
@interface CS_ReportGenerator ()
{
    NSArray *headerTitles;
    NSArray *headerValues;
    NSMutableArray *reportDataDetails;
    NSInteger cs_ReportProcess;
    NSString *stringFromDateToDate;
}

@property (nonatomic , strong) RapidCustomerLoyalty *rapidCustomerLoyalty;

@end
@implementation CS_ReportGenerator

-(instancetype)initWithCSReportHeaderFileds:(NSArray *)headerFields withReportValueFields:(NSArray *)valueFields withReportProcess:(CS_ReportProcess)cs_report withReportDetails:(NSMutableArray *)reportDetails customerDetail:(RapidCustomerLoyalty*)rapidCustomerDetail withFromDateAndTime:(NSString*)strDate
{
    self = [super init];
    if (self) {
        headerTitles = headerFields;
        headerValues = valueFields;
        cs_ReportProcess = cs_report;
        reportDataDetails = reportDetails;
        self.rapidCustomerLoyalty = rapidCustomerDetail;
        stringFromDateToDate = strDate;
    
    }
    return self;
}


-(void)generateReportHTML
{
    NSArray *arrayfromDate = [stringFromDateToDate componentsSeparatedByString:@" - "];

    self.reportHTMLString= @"";
    self.reportHTMLString = [[NSBundle mainBundle] pathForResource:@"CS_Report" ofType:@"html"];
    self.reportHTMLString = [NSString stringWithContentsOfFile:self.reportHTMLString encoding:NSUTF8StringEncoding error:nil];
    self.reportHTMLString = [self configureReportHeader];
    self.reportHTMLString = [self configureReportType:self.reportHTMLString];
    self.reportHTMLString = [self configureCustomerLoyaltyHeader];
    self.reportHTMLString = [self configureFromDate:arrayfromDate.firstObject];
    self.reportHTMLString = [self configureToDate:arrayfromDate.lastObject];


    [self configureCustomerLoyaltyDetail];
    
    
    NSData *data = [self.reportHTMLString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths.firstObject;
    self.reportHTMLString = [documentsDirectory stringByAppendingPathComponent:@"CSReport.html"];
    
    self.reportHTMLString = [self writeDataOnCacheDirectory:data withHtml:self.reportHTMLString];

}
-(NSString *)writeDataOnCacheDirectory:(NSData *)data withHtml:(NSString *)html
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:html])
    {
        [[NSFileManager defaultManager] removeItemAtPath:html error:nil];
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths.firstObject;
    html = [documentsDirectory stringByAppendingPathComponent:@"CSReport.html"];
    [data writeToFile:html atomically:YES];
    return html;
}
-(NSString *)configureReportHeader
{
    return  [self.reportHTMLString stringByReplacingOccurrencesOfString:@"CUSTOMER_NAME" withString:self.rapidCustomerLoyalty.customerName];
}

-(NSString *)configureFromDate:(NSString*)strFromDate
{
    if ([strFromDate isEqualToString:@"All History"])
    {
        strFromDate = @"-";
    }
    return [self.reportHTMLString stringByReplacingOccurrencesOfString:@"FROM_DATE" withString:strFromDate];
}
-(NSString *)configureToDate:(NSString*)strToDate
{
    if ([strToDate isEqualToString:@"All History"])
    {
        strToDate = @"Till Date";
    }
    return [self.reportHTMLString stringByReplacingOccurrencesOfString:@"TO_DATE" withString:strToDate];
}

-(NSString *)configureReportType:(NSString *)reportType
{
    NSString * strReportType;
    if (cs_ReportProcess == CS_InvoiceReport) {
        strReportType =  [self.reportHTMLString stringByReplacingOccurrencesOfString:@"REPORT_TYPE" withString:@"Customer Loyalty Report"];
    }
    else if (cs_ReportProcess == CS_ItemReport) {
        strReportType =  [self.reportHTMLString stringByReplacingOccurrencesOfString:@"REPORT_TYPE" withString:@"Customer Loyalty Report"];
    }
    else if (cs_ReportProcess == CS_HouseCharge)
    {
        strReportType =  [self.reportHTMLString stringByReplacingOccurrencesOfString:@"REPORT_TYPE" withString:@"Customer House Charge Report"];
    }
    return strReportType;
}

-(NSString *)configureCustomerLoyaltyHeader
{
    NSString *headerString = @"";
    for (NSNumber *header in headerTitles) {
        
        NSString *headerValue = @"";
        if (cs_ReportProcess == CS_InvoiceReport) {
            headerValue =  [self invoiceHeaderFor:header.integerValue];
        }
        else if (cs_ReportProcess == CS_ItemReport) {
            headerValue =  [self itemHeaderFor:header.integerValue];
        }
        else if (cs_ReportProcess == CS_HouseCharge)
        {
            headerValue = [self houseChargeForHeader:header.integerValue];
        }
        
     headerString = [headerString stringByAppendingString:[NSString stringWithFormat:@"<th style=\"text-align: left;\">%@</th>",headerValue]];
    }
    return [self.reportHTMLString stringByReplacingOccurrencesOfString:@"CUSTOMER_SALES_HEADER_TITLES" withString:headerString];
}

-(void)configureCustomerLoyaltyDetail
{
    if (cs_ReportProcess == CS_InvoiceReport) {
        self.reportHTMLString = [self configureCustomerLoyaltyReportHeaderType:@"Customer Invoice List"];
    self.reportHTMLString =  [self configureCustomerLoyaltyInvoiceDetail];
    }
    else if (cs_ReportProcess == CS_ItemReport) {
        self.reportHTMLString = [self configureCustomerLoyaltyReportHeaderType:@"Customer Item List"];
     self.reportHTMLString =  [self configureCustomerLoyaltyItemDetail];
    }
    else if(cs_ReportProcess == CS_HouseCharge)
    {
        self.reportHTMLString = [self configureCustomerLoyaltyReportHeaderType:@"House Charge List"];
        self.reportHTMLString =  [self configureCustomerLoyaltyHouseCharge];

 
    }
    
}

-(NSString *)configureCustomerLoyaltyReportHeaderType:(NSString*)reportHeaderString
{
        return [self.reportHTMLString stringByReplacingOccurrencesOfString:@"CS_REPORT_NAME" withString:reportHeaderString];
}
-(NSString *)configureCustomerLoyaltyItemDetail
{
    NSString *headerString = @"";
    
    for (CS_Item *cs_Item in reportDataDetails) {
        
        NSString *trString = @"<tr style=\"font-size:17px\">";
        NSString *tdString = @"";
        for (NSString *header in headerValues) {
            tdString = [tdString stringByAppendingString:[NSString stringWithFormat:@"<td style=\"text-align: left; border-bottom: 1px solid #1f2f4a;\">%@</td>",[cs_Item valueForKey:header]]];
        }
        trString = [trString stringByAppendingString:tdString];
        trString = [trString stringByAppendingString:@"</tr>"];
        headerString = [headerString stringByAppendingString:trString];
    }
    return [self.reportHTMLString stringByReplacingOccurrencesOfString:@"CUSTOMER_SALES_HEADER_DETAILS" withString:headerString];

}

-(NSString *)configureCustomerLoyaltyHouseCharge
{
    NSString *headerString = @"";
    
    for (CL_HouseCharge *cl_HouseCharge in reportDataDetails) {
        
        NSString *trString = @"<tr style=\"font-size:17px\">";
        NSString *tdString = @"";
        for (NSString *header in headerValues) {
            tdString = [tdString stringByAppendingString:[NSString stringWithFormat:@"<td style=\"text-align: left; border-bottom: 1px solid #1f2f4a;\">%@</td>",[cl_HouseCharge valueForKey:header]]];
        }
        trString = [trString stringByAppendingString:tdString];
        trString = [trString stringByAppendingString:@"</tr>"];
        headerString = [headerString stringByAppendingString:trString];
    }
    return [self.reportHTMLString stringByReplacingOccurrencesOfString:@"CUSTOMER_SALES_HEADER_DETAILS" withString:headerString];
    
}
-(NSString *)configureCustomerLoyaltyInvoiceDetail
{
    NSString *headerString = @"";
    
    for (CS_Invoice *cs_Invoice in reportDataDetails) {
        
       NSString *trString = @"<tr style=\"font-size:17px : bore\">";
        NSString *tdString = @"";
        for (NSString *header in headerValues) {
            tdString = [tdString stringByAppendingString:[NSString stringWithFormat:@"<td style=\"text-align: left; border-bottom: 1px solid #1f2f4a;\">%@</td>",[cs_Invoice valueForKey:header]]];
        }
        trString = [trString stringByAppendingString:tdString];
        trString = [trString stringByAppendingString:@"</tr>"];
        headerString = [headerString stringByAppendingString:trString];
    }
    return [self.reportHTMLString stringByReplacingOccurrencesOfString:@"CUSTOMER_SALES_HEADER_DETAILS" withString:headerString];
}

-(NSString *)invoiceHeaderFor:(CS_InvoiceReportHeaderFields)cs_InvoiceReportHeaderFields
{
    
    NSString *invoiceHeader = @"";
    switch (cs_InvoiceReportHeaderFields) {
        case CS_InvoiceReportInvoiceDate:
            invoiceHeader = @"Date";
            break;
            
        case CS_InvoiceReportInvoiceNo:
            invoiceHeader = @"Invoice#";
            break;
        
        case CS_InvoiceReportInvoicePrice:
            invoiceHeader = @"Total($)";
            break;
            
        case CS_InvoiceReportInvoiceQty:
            invoiceHeader = @"QTY";
            break;

        case CS_InvoiceReportInvoicePaymentType:
            invoiceHeader = @"Payment Type";
            break;
            
        default:
            break;
    }
    return invoiceHeader;
}


-(NSString *)itemHeaderFor:(CS_ItemReportHeaderFields)cs_ItemReportHeaderFields
{
    NSString *invoiceHeader = @"";

    switch (cs_ItemReportHeaderFields) {
        case CS_ItemReportItemDate:
            invoiceHeader = @"Date";
            break;
        case CS_ItemReportInvoiceNo:
            invoiceHeader = @"Invoice#";
            
            break;
        case CS_ItemReportUpc:
            invoiceHeader = @"UPC";
            
            break;
        case CS_ItemReportItemName:
            invoiceHeader = @"Item Name";
            
            break;
        case CS_ItemReportItemCost:
            invoiceHeader = @"Cost($)";
            
            break;
        case CS_ItemReportItemPrice:
            invoiceHeader = @"Price($)";
            
            break;
            
        case CS_ItemReportItemMargin:
            invoiceHeader = @"Margin(%)";
            
            break;
            
        default:
            break;
    }
    return invoiceHeader;
}

-(NSString *)houseChargeForHeader:(CS_HouseChargeReportHeaderFields)cs_HouseChargeReportHeaderFields
{
    NSString *houseChargeHeader = @"";
    
    switch (cs_HouseChargeReportHeaderFields) {
        case CS_HouseChargeReportDate:
            houseChargeHeader = @"Date And Time";
            break;
        case CS_HouseChargeReportInvoice:
            houseChargeHeader = @"Invoice#";
            
            break;
        case CS_HouseChargeReportDebit:
            houseChargeHeader = @"Debit($)";
            
            break;
        case CS_HouseChargeReportCredit:
            houseChargeHeader = @"Credit($)";
            
            break;
        case CS_HouseChargeReportBalance:
            houseChargeHeader = @"Balance($)";
            break;
            
        default:
            break;
    }
    return houseChargeHeader;
}



@end
