//
//  InvoiceData_T+Dictionary.m
//  RapidRMS
//
//  Created by Siya Infotech on 22/04/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "InvoiceData_T+Dictionary.h"

@implementation InvoiceData_T (Dictionary)

-(NSData *)archivedDataWithInvoiceObject:(NSMutableArray *)invoiceItemData
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:invoiceItemData];
    return data;
}

-(void)updateInvoiceFromDictionary :(NSDictionary *)responseDictionary
{
    NSMutableArray *invoiceItemData = [[responseDictionary valueForKey:@"InvoiceDetail" ] valueForKey:@"InvoiceItemDetail"];
    self.invoiceItemData = [self archivedDataWithInvoiceObject:invoiceItemData];
    
    
    NSMutableArray *invoiceMstData = [[responseDictionary valueForKey:@"InvoiceDetail" ] valueForKey:@"InvoiceMst"];
    NSMutableDictionary *invoiceMasterDictionary = [invoiceMstData.firstObject firstObject];
    invoiceMasterDictionary[@"IsOffline"] = @"1";
    self.invoiceMstData = [self archivedDataWithInvoiceObject:invoiceMstData];
    
    NSMutableArray *invoicePaymentData = [[responseDictionary valueForKey:@"InvoiceDetail" ] valueForKey:@"InvoicePaymentDetail"];
    self.invoicePaymentData = [self archivedDataWithInvoiceObject:invoicePaymentData];
}
-(void)updateInvoiceFromPetro:(NSDictionary *)responseDictionary
{
    NSMutableArray *invoiceItemData = [[responseDictionary valueForKey:@"InvoiceDetail" ] valueForKey:@"InvoiceItemDetail"];
    self.invoiceItemData = [self archivedDataWithInvoiceObject:invoiceItemData];
    
    
    NSMutableArray *invoiceMstData = [[responseDictionary valueForKey:@"InvoiceDetail" ] valueForKey:@"InvoiceMst"];
    self.invoiceMstData = [self archivedDataWithInvoiceObject:invoiceMstData];
    
    NSMutableArray *invoicePaymentData = [[responseDictionary valueForKey:@"InvoiceDetail" ] valueForKey:@"InvoicePaymentDetail"];
    self.invoicePaymentData = [self archivedDataWithInvoiceObject:invoicePaymentData];
    self.isUpload = @(0);
}

-(void)updateInvoiceIsOffLine
{
    NSMutableArray *invoiceMstData = [[NSKeyedUnarchiver unarchiveObjectWithData:self.invoiceMstData] firstObject];
    NSMutableDictionary *invoiceMasterDictionary = [invoiceMstData.firstObject firstObject];
    invoiceMasterDictionary[@"IsOffline"] = @"1";
    self.invoiceMstData = [self archivedDataWithInvoiceObject:invoiceMstData];
}

-(NSDictionary *)invoiceDetailDictionary
{
    NSMutableDictionary *invoiceDetailDictionary=[[NSMutableDictionary alloc]init];
    NSArray *invoicePaymentArray = [[NSKeyedUnarchiver unarchiveObjectWithData:self.invoicePaymentData] firstObject];
    
    NSString *accountNo = @"";
    NSString *payName = @"";
    NSString *cardHolderName = @"";
    CGFloat cahngeDue = 0.00;

    for (NSDictionary *invoicePaymentDictionary in invoicePaymentArray)
    {
        accountNo = [accountNo stringByAppendingString:[invoicePaymentDictionary valueForKey:@"AccNo"]];
        payName = [payName stringByAppendingString:[invoicePaymentDictionary valueForKey:@"PayMode"]];
        cardHolderName = [cardHolderName stringByAppendingString:[invoicePaymentDictionary valueForKey:@"CardHolderName"]];
        cahngeDue+= [[invoicePaymentDictionary valueForKey:@"ReturnAmount"] floatValue];
    }
    NSDictionary *invoiceMasterDictionary = [[[NSKeyedUnarchiver unarchiveObjectWithData:self.invoiceMstData] firstObject] firstObject];
    invoiceDetailDictionary[@"AccNo"] = accountNo;
    invoiceDetailDictionary[@"BillAmount"] = [invoiceMasterDictionary valueForKey:@"BillAmount"];
    invoiceDetailDictionary[@"ChangeDue"] = [NSString stringWithFormat:@"%f",cahngeDue];
    invoiceDetailDictionary[@"CustomerName"] = [NSString stringWithFormat:@"%@",cardHolderName];
    invoiceDetailDictionary[@"DiscountAmount"] = [invoiceMasterDictionary valueForKey:@"DiscountAmount"];
    invoiceDetailDictionary[@"InvoiceDate"] = [invoiceMasterDictionary valueForKey:@"Datetime"];
    invoiceDetailDictionary[@"RegisterInvNo"] = [invoiceMasterDictionary valueForKey:@"RegisterInvNo"];
    invoiceDetailDictionary[@"SubTotal"] = [invoiceMasterDictionary valueForKey:@"SubTotal"];
    invoiceDetailDictionary[@"TaxAmount"] = [invoiceMasterDictionary valueForKey:@"TaxAmount"];
    invoiceDetailDictionary[@"UserName"] = [invoiceMasterDictionary valueForKey:@"UserId"];
    invoiceDetailDictionary[@"payName"] = [NSString stringWithFormat:@"%@",payName];
    invoiceDetailDictionary[@"InvoiceNo"] = [invoiceMasterDictionary valueForKey:@"InvoiceNo"];
    return invoiceDetailDictionary;
}

-(NSMutableArray *)totalInvoiceDetailForObject
{
    NSMutableArray * invoiceDetail = [[NSMutableArray alloc] init];
    NSMutableDictionary * invoiceDetailDict = [[NSMutableDictionary alloc] init];
    invoiceDetailDict[@"InvoiceMst"] = [[NSKeyedUnarchiver unarchiveObjectWithData:self.invoiceMstData] firstObject];
    invoiceDetailDict[@"InvoiceItemDetail"] = [[NSKeyedUnarchiver unarchiveObjectWithData:self.invoiceItemData] firstObject];
    invoiceDetailDict[@"InvoicePaymentDetail"] = [[NSKeyedUnarchiver unarchiveObjectWithData:self.invoicePaymentData] firstObject];
    [invoiceDetail addObject:invoiceDetailDict];
    return invoiceDetail;
}



@end
