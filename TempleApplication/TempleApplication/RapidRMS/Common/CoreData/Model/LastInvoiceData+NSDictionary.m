//
//  LastInvoiceData+NSDictionary.m
//  RapidRMS
//
//  Created by siya-IOS5 on 9/23/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "LastInvoiceData+NSDictionary.h"

@implementation LastInvoiceData (NSDictionary)
-(NSData *)archivedDataWithInvoiceObject:(NSMutableArray *)invoiceItemData
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:invoiceItemData];
    return data;
}

-(void)updateInvoiceFromDictionary :(NSDictionary *)responseDictionary
{
    NSMutableArray *invoiceItemData = [responseDictionary valueForKey:@"InvoiceDetail" ];
    self.invoiceData = [self archivedDataWithInvoiceObject:invoiceItemData];
}

@end
