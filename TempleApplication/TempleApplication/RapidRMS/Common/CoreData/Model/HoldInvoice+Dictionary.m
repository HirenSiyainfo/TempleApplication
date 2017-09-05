//
//  HoldInvoice+Dictionary.m
//  RapidRMS
//
//  Created by siya-IOS5 on 3/2/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "HoldInvoice+Dictionary.h"

@implementation HoldInvoice (Dictionary)

-(NSDictionary *)holdInvoiceDictionary
{
    return nil;
}

-(NSData *)archivedDataWithHoldObject:(NSMutableDictionary *)holdInvoiceData
{
    return [NSKeyedArchiver archivedDataWithRootObject:holdInvoiceData];
}

-(void)updateholdInvoiceFromDictionary :(NSDictionary *)holdInvoiceDictionary
{
    self.holdRemark = holdInvoiceDictionary[@"HoldRemark"];
    self.holdData = [self archivedDataWithHoldObject:holdInvoiceDictionary[@"HoldData"]];
    self.holdDate = [NSDate date];
    self.billAmount = @([holdInvoiceDictionary[@"HoldBillAmount"] floatValue]);
    self.holdUserName = holdInvoiceDictionary[@"HoldUserName"];
    self.transActionNo = @([holdInvoiceDictionary[@"HoldTransActionNo"]integerValue]);
}
@end
