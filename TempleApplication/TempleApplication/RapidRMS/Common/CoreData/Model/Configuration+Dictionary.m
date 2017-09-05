//
//  Configuration+Dictionary.m
//  RapidRMS
//
//  Created by Siya Infotech on 22/04/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "Configuration+Dictionary.h"

@implementation Configuration (Dictionary)

-(void)incrementInvoiceNo
{
    NSInteger number = self.invoiceNo.integerValue;
    number++;
    self.invoiceNo = @(number);
}

@end
