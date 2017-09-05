//
//  InvoiceData_T+Dictionary.h
//  RapidRMS
//
//  Created by Siya Infotech on 22/04/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "InvoiceData_T.h"

@interface InvoiceData_T (Dictionary)

-(NSData *)archivedDataWithInvoiceObject:(NSMutableArray *)invoiceItemData;
-(void)updateInvoiceFromDictionary :(NSDictionary *)responseDictionary;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *invoiceDetailDictionary;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSMutableArray *totalInvoiceDetailForObject;

-(void)updateInvoiceFromPetro:(NSDictionary *)responseDictionary;
-(void)updateInvoiceIsOffLine;
@end
