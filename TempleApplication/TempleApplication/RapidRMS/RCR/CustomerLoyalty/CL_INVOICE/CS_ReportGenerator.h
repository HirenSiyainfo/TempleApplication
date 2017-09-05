//
//  CS_ReportGenerator.h
//  RapidRMS
//
//  Created by siya-IOS5 on 12/29/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RapidCustomerLoyalty.h"

typedef NS_ENUM(NSInteger,CS_ReportProcess)
{
    CS_InvoiceReport,
    CS_ItemReport,
    CS_HouseCharge,
};


typedef NS_ENUM(NSInteger,CS_InvoiceReportHeaderFields)
{
    CS_InvoiceReportInvoiceDate,
    CS_InvoiceReportInvoiceNo,
    CS_InvoiceReportInvoicePrice,
    CS_InvoiceReportInvoiceQty,
    CS_InvoiceReportInvoicePaymentType,
};

typedef NS_ENUM(NSInteger,CS_ItemReportHeaderFields)
{
    CS_ItemReportItemDate,
    CS_ItemReportInvoiceNo,
    CS_ItemReportUpc,
    CS_ItemReportItemName,
    CS_ItemReportItemCost,
    CS_ItemReportItemPrice,
    CS_ItemReportItemMargin
};

typedef NS_ENUM(NSInteger,CS_HouseChargeReportHeaderFields)
{
    CS_HouseChargeReportDate,
    CS_HouseChargeReportInvoice,
    CS_HouseChargeReportCredit,
    CS_HouseChargeReportDebit,
    CS_HouseChargeReportBalance,
};


@interface CS_ReportGenerator : NSObject
{

}
-(instancetype)initWithCSReportHeaderFileds:(NSArray *)headerFields withReportValueFields:(NSArray *)valueFields withReportProcess:(CS_ReportProcess)cs_report withReportDetails:(NSMutableArray *)reportDetails customerDetail:(RapidCustomerLoyalty*)rapidCustomerDetail withFromDateAndTime:(NSString*)strDate NS_DESIGNATED_INITIALIZER;
-(void)generateReportHTML;

@property (nonatomic ,strong) NSString *reportHTMLString;


@end
